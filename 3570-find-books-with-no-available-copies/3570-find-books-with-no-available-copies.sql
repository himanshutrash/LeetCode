# Write your MySQL query statement below
SELECT 
	lb.book_id,
	lb.title,
    lb.author,
    lb.genre,
    lb.publication_year,
    lb.total_copies AS current_borrowers  
FROM library_books lb 
WHERE lb.total_copies = (
							SELECT 
								COUNT(1) 
							FROM borrowing_records br 
							WHERE br.book_id = lb.book_id AND br.return_date IS NULL
						)
ORDER BY lb.total_copies DESC, lb.title ASC;